from django.urls import path
from main.views import HelloView


urlpatterns = [
    path('', HelloView.as_view(), name='hello_view'),
]