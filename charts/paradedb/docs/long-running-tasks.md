# Executing Long-running Tasks

By setting `cluster.console.enabled=true`, the chart deploys a StatefulSet with a console pod for executing long-running tasks. This is useful for tasks that need to run in the background or for batch processing, such as `CREATE INDEX`. The intent is to use this console pod to run commands in the background without maintaining a persistent client connection. Because the console pod is on the cluster, it is less susceptible to network issues.

> [!NOTE]
> We don't provision a PodDisruption Budget (PDB) for the console StatefulSet. Node maintenance or other disruptions may cause the console pod to be evicted, killing your session.
>
> The console pod has `root` access so that you can use `apt install` to install any additional tools you may need. Keep in mind that while the root user home folder (`/root`) is persisted, any tools you install will not be persisted if the pod restarts.
>
> All the utilities in the pod are installed during the pod startup, so it may take a few seconds before they become available, after the pod has restarted.

## Connecting to the Console Pod

To use the console pod, you can run the following command:

```bash
kubectl --namespace <namespace> exec --stdin --tty statefulset/<cluster-name>-console -- bash
```

## Database credentials

We provide the database credentials as environment variables in the console pod. You can access them using:

* `$DB_APP_URI` - Connection URI for the default application user.
* `$DB_SUPERUSER_URI` - Connection URI for the `postgres` superuser.

## Executing queries

To run a command in the background you can use the `nohup` command. For example, to create an index in the background:

```bash
nohup psql "$DB_SUPERUSER_URI/<db-name>" -c "CREATE INDEX orders_idx ON orders USING bm25 (order_id, customer_name) WITH (key_field='order_id');" 2>&1 > command.log &
```

To check on the status of the command, you can use the `tail` command:

```bash
tail -f command.log
```

## Advanced usage with `screen`

You can also use the `screen` utility to run commands in the background and keep them running even if you disconnect from the console pod. Here are some basic commands to get you started:

* Start a new screen session

```bash
screen -S mysession
```

* List all screen sessions

```bash
screen -list
```

* To detach from a screen session without stopping it, press `Ctrl + A`, then `D`.
* You can reattach to a screen session with:

```bash
screen -r mysession
```
