
from django.db import models


class Account(models.Model):

    name = models.CharField(
        blank=False,
        null=False,
        max_length=100
    )

    balance = models.DecimalField(
        blank=False,
        null=False,
        max_digits=11,
        decimal_places=2
    )

    type = models.CharField(
        blank=False,
        null=False,
        max_length=100
    )

    @classmethod
    def create(cls, name, balance, type):
        name = name.upper()
        account = cls(name=name, balance=balance, type=type)
        return account



