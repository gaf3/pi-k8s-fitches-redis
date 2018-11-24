# pi-k8s-fitches-redis

# Data Stuctures

## speech

Channel for converting text to speech

JSON object:
- timestamp - Time this message should be spoked
- node - The node on which to speak
  - If omitted, play on all
- text - The text to speak
- language - The language to speak it in
  - If ommitted, defaults to "en"

Example:

```json
{
    "timestamp": 1543074126,
    "node": "pi-k8s-node02",
    "text": "Hi",
    "language": "en"
}
```

## event

Channel for tracking pushed buttons

JSON object:
- timestamp - Time of the event
- node - The node on which the event happened
- type - Rising or falling
- gpio_port - The GPIO port that rose

Example:

```json
{
    "timestamp": 1543074126,
    "node": "pi-k8s-node02",
    "type": "rising",
    "gpio_port": 4
}
```

## chore

path: `/node/<node>/chore` Only one chore per node right now

JSON object:
- chore - The name of the chore
- name - Who's reponsible for the chore
- node - The node on which the event happened
- started - Time it started
- notified - Time last notified (start, complete)
- completed - Time it completed (non existement if incomplete)
- tasks - array
  - task - The name of the task
  - interval - Interval in sends to remind
  - started - Time started
    - If non existent, no reminder
  - notified - Time last notified (start, reminder, complete)
  - completed - Time it completed (non existement if incomplete)

Example:

```json
{
    "chore": "get ready for school",
    "name": "Azalea",
    "node": "pi-k8s-azalea",
    "started": 1543074126,
    "completed": 1543075126,
    "tasks": [
        {
            "task": "get out of bed",
            "interval": 15,
            "started": 1543074126,
            "notified": 1543074226,
            "completed": 1543074226
        },
        {
            "task": "get dressed",
            "interval": 60,
            "started": 1543074326,
            "notified": 1543074426,
            "completed": 1543074526
        },
        {
            "task": "brush your teeth",
            "interval": 60,
            "started": 1543074526,
            "notified": 1543074626,
            "completed": 1543074726
        },
        {
            "task": "put on your boots, coat, and hat",
            "interval": 60,
            "started": 1543074826,
            "notified": 1543074926,
            "completed": 1543075126
        }
    ]
}
```

Chores and tasks are phrased this way to work with the text to speech.  When the chore starts it'll say `"{name}, time to {chore}"`.

Then for each task, it'll say `"{name}, please {task}"` until done and then say `"{name}, you did {task} in {minutes} minute(s), {seconds} second(s)"`

Then in the end it'll day `"{name}, thank you. You did {chore} in {minutes} minuites and {seconds} seconds"`.

For the about example, this is what's said:
- "Azelea, time to get ready for school" once
- "Azelea, please get out of bed" every 15 seconds 
- "Azalea, you did get out of bed in 1 minute, 40 seconds" once
- "Azelea, please get dressed" every 60 seconds 
- "Azalea, you did get dressed in 3 minutes, 20 seconds" once
- "Azelea, please brush your teeth" every 60 seconds 
- "Azalea, you did brush your teethin 3 minutes, 20 seconds" once
- "Azelea, please put on your boots, coat, and hat" every 60 seconds 
- "Azalea, you did put on your boots, coat, and hat in 3 minutes, 20 seconds" once
- "Azalea, thank you. You did get ready for school in 16 minutes, 40 seconds" once

We'll probably need a library for interacting with the redis object. Basically as a task is completed, the next must be started until the last task is completed, then everything's done.

We could go through the API which would make the code simpler, but we'd introduce a lot of risk.

If everything (internal) interacts with Redis directly and Redis goes down, messages won't be pulled and everything stops.

If everything (internal) interacts withe API and the API goes down, daemons will be pulling messages but unable to process and we'll have lost state. 

Templates will be stored in a ConfigMap and are like an array of chore data without all the specifics:

Example:

```json
[
    {
        "chore": "get ready for school",
        "tasks": [
            {
                "task": "get out of bed",
                "interval": 15
            },
            {
                "task": "get dressed",
                "interval": 60
            },
            {
                "task": "brush your teeth",
                "interval": 60
            },
            {
                "task": "put on your boots, coat, and hat",
                "interval": 60
            }
        ]
    },
    {
        "chore": "clean your room",
        "tasks": [
            {
                "task": "put your blankets and pillows on the bed",
                "interval": 60
            },
            {
                "task": "put your dirty clothes in the hamper",
                "interval": 60
            },
            {
                "task": "put away your books",
                "interval": 60
            },
            {
                "task": "put away your toys",
                "interval": 60
            },
            {
                "task": "throw away the trash",
                "interval": 60
            },
            {
                "task": "sweep the floor",
                "interval": 120
            },
            {
                "task": "make the bed",
                "interval": 60
            }
        ]
    },
    {
        "chore": "get ready for bed",
        "tasks": [
            {
                "task": "put on pajamas",
                "interval": 60
            },
            {
                "task": "brush your teeth",
                "interval": 60
            },
            {
                "task": "read a story",
                "interval": 300
            },
            {
                "task": "get in bed",
                "interval": 15
            }
        ]
    }
]
```
