from django.template.response import TemplateResponse
from django.views import View


class HelloView(View):

    def get(self, request):
        return TemplateResponse(request, 'main/hello.html')
