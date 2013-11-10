from django.conf.urls import patterns, url
from pollugraphics import views

urlpatterns = patterns('',
	url(r'^$', views.index, name='index')
)
