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
- name - The name of the chore
- user - Who's reponsible for the chore
- node - The node on which the event happened
- started - Time it started
- notified - Time last notified (start, complete)
- completed - Time it completed (non existement if incomplete)
- tasks - array
  - name - The name of the task
  - interval - Interval in sends to remind
  - started - Time started
    - If non existent, no reminder
  - notified - Time last notified (start, reminder, complete)
  - completed - Time it completed (non existement if incomplete)

Example:

```json
{
    "name": "get ready for school",
    "user": "Azalea",
    "node": "pi-k8s-azalea",
    "started": 1543074126,
    "completed": 1543075126,
    "tasks": [
        {
            "name": "get out of bed",
            "interval": 15,
            "started": 1543074126,
            "notified": 1543074226,
            "completed": 1543074226
        },
        {
            "name": "get dressed",
            "interval": 60,
            "started": 1543074326,
            "notified": 1543074426,
            "completed": 1543074526
        },
        {
            "name": "brush your teeth",
            "interval": 60,
            "started": 1543074526,
            "notified": 1543074626,
            "completed": 1543074726
        },
        {
            "name": "pur on your boots, coat, and hat",
            "interval": 60,
            "started": 1543074826,
            "notified": 1543074926,
            "completed": 1543075126
        }
    ]
}
```

We'll probably need a library for interacting with the redis object. 

We could go through the API which would make the code simpler, but we'd introduce a lot of risk.

If everything (internal) interacts with Redis directly and Redis goes down, messages won't be pulled and everything stops.

If everything (internal) interacts withe API and the API goes down, daemons will be pulling messages but unable to process and we'll have lost state. 