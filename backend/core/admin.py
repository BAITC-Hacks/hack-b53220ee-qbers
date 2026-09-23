from django.contrib import admin

from .models import BudgetPlan, ExchangeRates

admin.site.register(BudgetPlan)
admin.site.register(ExchangeRates)
