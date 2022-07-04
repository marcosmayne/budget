from django.test import TestCase
from main.views import HelloView


class HelloViewTest(TestCase):

    def test_renders_hello_message(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Hello Django')
