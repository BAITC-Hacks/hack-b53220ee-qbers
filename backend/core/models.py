from django.db import models


class WaitlistSignup(models.Model):
    """Rows created by the landing-page form — proves Django forms + Postgres work."""

    name = models.CharField(max_length=120)
    email = models.EmailField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} <{self.email}>"


class Metric(models.Model):
    """Demo time series rendered by Google Charts on the landing page."""

    label = models.CharField(max_length=20)
    users = models.PositiveIntegerField()
    requests = models.PositiveIntegerField()
    order = models.PositiveSmallIntegerField(default=0)

    class Meta:
        ordering = ["order"]

    def __str__(self):
        return self.label


class Location(models.Model):
    """Pins dropped on the Google Map."""

    name = models.CharField(max_length=120)
    lat = models.FloatField()
    lng = models.FloatField()

    def __str__(self):
        return self.name
