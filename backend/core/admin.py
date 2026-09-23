from django.contrib import admin

from .models import Location, Metric, WaitlistSignup

admin.site.register(WaitlistSignup)
admin.site.register(Metric)
admin.site.register(Location)
