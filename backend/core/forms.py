from django import forms

from .models import WaitlistSignup


class WaitlistForm(forms.ModelForm):
    class Meta:
        model = WaitlistSignup
        fields = ["name", "email"]
