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
- id - The id to access the chore (same as node for now)
- label - The label used to identify the chore
- text - The text of the chore
- person - Who's reponsible for the chore
- node - The node on which the event happened
- language - The language to use
- start - Time it started
- delay - Delay to start reminding (in secs)
- end - Time it was completd or skipped etc
- tasks - array
  - id - The id to access the task (index for now)
  - text - The text of the task
  - paused - If true, task is paused
  - skipped - If true, task is skipped
  - delay - Delay to start reminding (in secs)
  - interval - Interval in sends to remind (in secs)
  - start - Time started
    - If non existent, no reminder
  - notified - Time last notified (start, reminder, complete)
  - end - Time it completed (non existement if incomplete)

  If there's an interval in the chore, all intervals in the tasks will be ignored. 

  If there's no intercal in the task, it cannot be used with the next button. 

Example:

```json
{
    "id": "pi-k8s-azalea",
    "label": "Before care, Azi",
    "text": "get ready for school",
    "person": "Azalea",
    "node": "pi-k8s-azalea",
    "language": "en",
    "start": 1543074126,
    "end": 1543075126,
    "task": 3,
    "tasks": [
        {
            "id": 0,
            "text": "get out of bed",
            "interval": 15,
            "start": 1543074126,
            "notified": 1543074226,
            "end": 1543074226
        },
        {
            "id": 1,
            "text": "get dressed",
            "interval": 60,
            "start": 1543074326,
            "notified": 1543074426,
            "end": 1543074526
        },
        {
            "id": 2,
            "text": "brush your teeth",
            "interval": 60,
            "start": 1543074526,
            "notified": 1543074626,
            "end": 1543074726
        },
        {
            "id": 3,
            "text": "put on your boots, coat, and hat",
            "interval": 60,
            "start": 1543074826,
            "notified": 1543074926,
            "end": 1543075126
        }
    ]
}
```

Chores and tasks are phrased this way to work with the text to speech.  When the chore starts it'll say `"{name}, time to {chore}"`.

Then for each task, it'll say `"{name}, please {task}"` until done and then say `"{name}, you did {task} in {minutes} minute(s), {seconds} second(s)"`

If a task is skipped, it'll say `"{name}, you do not need to {task}"`

If a task is paused, it'll say `"{name}, you do not need to {task} yet"`

If a task is resumed, it'll say `"{name}, please again {task}"`

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

Templates will be stored in a ConfigMap as yaml and not requiring all the specifics:

Example:

We're not bothering with the id's as they'll be added based on node/position

```json
[
    {
        "label": "Get ready for school and before care",
        "text": "get ready for school",
        "tasks": [
            {
                "text": "get out of bed",
                "interval": 15
            },
            {
                "text": "get dressed",
                "interval": 60
            },
            {
                "text": "brush your teeth",
                "interval": 60
            },
            {
                "text": "put on your boots, coat, and hat",
                "interval": 60
            }
        ]
    },
    {
        "label": "Joran's list for cleaning his room",
        "text": "clean your room",
        "person": "Joran",
        "node": "pi-k8s-joran",
        "tasks": [
            {
                "text": "put your blankets and pillows on the bed",
                "interval": 60
            },
            {
                "text": "put your dirty clothes in the hamper",
                "interval": 60
            },
            {
                "text": "put away your books",
                "interval": 60
            },
            {
                "text": "put away your toys",
                "interval": 60
            },
            {
                "text": "throw away the trash",
                "interval": 60
            },
            {
                "text": "sweep the floor",
                "interval": 120
            },
            {
                "text": "make the bed",
                "interval": 60
            }
        ]
    },
    {
        "label": "Both kids bed time routine",
        "text": "get ready for bed",
        "tasks": [
            {
                "text": "put on pajamas",
                "interval": 60
            },
            {
                "text": "brush your teeth",
                "interval": 60
            },
            {
                "text": "read a story",
                "interval": 300
            },
            {
                "text": "get in bed",
                "interval": 15
            }
        ]
    }
]
```
