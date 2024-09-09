CNPGClusterHighConnectionsWarning
=================================

Meaning
-------

This alert is triggered when the number of connections to the CloudNativePG cluster instance exceeds 85% of its capacity.

Impact
------

At 100% capacity, the CloudNativePG cluster instance will not be able to accept new connections. This will result in a service
disruption.

Diagnosis
---------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

Mitigation
----------

* Increase the maximum number of connections by increasing the `max_connections` PostgreSQL parameter.
* Use connection pooling by enabling PgBouncer to reduce the number of connections to the database.
