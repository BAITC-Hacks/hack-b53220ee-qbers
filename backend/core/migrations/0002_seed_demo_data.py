from django.db import migrations

METRICS = [
    ("Jan", 120, 900), ("Feb", 260, 1800), ("Mar", 410, 3200),
    ("Apr", 640, 4700), ("May", 980, 7100), ("Jun", 1420, 9800),
]

LOCATIONS = [
    ("HQ — San Francisco", 37.7749, -122.4194),
    ("Hack Lab — Oakland", 37.8044, -122.2712),
    ("Partner — Palo Alto", 37.4419, -122.1430),
    ("Partner — San Jose", 37.3382, -121.8863),
]


def seed(apps, schema_editor):
    Metric = apps.get_model("core", "Metric")
    Location = apps.get_model("core", "Location")
    for i, (label, users, requests) in enumerate(METRICS):
        Metric.objects.create(label=label, users=users, requests=requests, order=i)
    for name, lat, lng in LOCATIONS:
        Location.objects.create(name=name, lat=lat, lng=lng)


def unseed(apps, schema_editor):
    apps.get_model("core", "Metric").objects.all().delete()
    apps.get_model("core", "Location").objects.all().delete()


class Migration(migrations.Migration):
    dependencies = [("core", "0001_initial")]
    operations = [migrations.RunPython(seed, unseed)]
