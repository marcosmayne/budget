from django.test import TestCase
from main.models import Account


class AccountTest(TestCase):

    def test_if_name_account_is_uppercase(self):
        account = Account.create(name="test", balance=100.00, type="checking")
        self.assertEqual(account.name, "TEST")
        
    


