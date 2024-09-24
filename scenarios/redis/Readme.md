# Redis Chaos Scenario

The Redis Chaos Scenario is designed to test the stability and resilience of your Azure Cache for Redis instances. By introducing faults such as forced reboots, you can observe how applications depending on Redis handle sudden outages or disruptions and implement measures to improve their robustness.

## Configuring Chaos Studio for Redis

To configure Chaos Studio to create chaos experiments targeting Azure Cache for Redis:

1. Deploy Azure Cache for Redis using the provided Bicep template or through the Azure CLI.
2. Ensure the Chaos Studio resource provider is registered for your Azure subscription.
3. Define the chaos experiments specific to Redis using JSON format, which can include operations like rebooting nodes.
4. Set up the correct RBAC permissions to allow Chaos Studio's managed identity to perform actions on your Redis instances.

## Deploying a Sample Application

Deploy a simple application that uses Azure Cache for Redis to verify the impact of chaos experiments. Your application should be designed to interact with Redis for typical caching operations, such as fetching and updating data.

You may choose a basic key-value store scenario to illustrate how Redis is utilized:

```python
# Simple Python-based pseudocode for key-value interactions with Redis
import redis

# Connect to the Azure Cache for Redis
redis_client = redis.StrictRedis(host='hostname', port=port_number, password='password', ssl=True)

# Set a key-value pair in Redis
redis_client.set('hello', 'world')

# Retrieve and print the value for the key 'hello'
print(redis_client.get('hello'))
```

Replace 'hostname', 'port_number', and 'password' with your actual Redis instance details.

## Running Experiments

To execute the Redis chaos experiments:

1. Log in to Azure and prepare your environment for the chaos experiments:

    ```powershell
    .\scenarios\redis\1.login.ps1
    ```

2. Deploy the Redis instance or ensure it's running:

    ```powershell
    .\scenarios\redis\2.deploy_redis.ps1
    ```

3. Onboard the Redis instance to the Chaos Studio:

    ```powershell
    .\scenarios\redis\3.onboard_redis.ps1
    ```

4. Create chaos experiments targeting Redis:

    ```powershell
    .\scenarios\redis\4.create_experiment.ps1
    ```

5. Initiate the chaos experiments:

    ```powershell
    .\scenarios\redis\5.run_experiment.ps1
    ```

## Monitoring Progress

### Azure Portal
Monitor the progression of chaos experiments within your Azure Portal by navigating to the Chaos Studio service. Here, you can get detailed insights into each experiment's status, logs, and outcomes.

### Sample Application Logs
Examine the logs or outputs of your sample application for error messages or latency information related to Redis operations. These observations will be instrumental in understanding how your application copes with and recovers from Redis outages or performance issues.

By meticulously observing the effects of these chaos experiments, you can make informed decisions to enhance the resilience of applications using Azure Cache for Redis. These improvements may include implementing retry policies, failover mechanisms, or distributed caching strategies to mitigate the impact of similar events in a production setting.