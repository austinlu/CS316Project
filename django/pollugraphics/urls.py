from django.conf.urls import patterns, url
from pollugraphics import views

urlpatterns = patterns('',
	url(r'^$', views.index, name='index'),
	url(r'^county/(?P<county_id>\d+)/$', views.county, name='county'),
	url(r'^facility/(?P<facility_id>\d+)/$', views.facility, name='facility'),
    url(r'^county/(?P<county_id>\d+)/(?P<pollutant>\w+)/$', views.countyPollution, name='countyPollution'),
	url(r'^form/$', views.form, name='form'),
	url(r'^compare_county/(?P<county_id>\d+)/', views.compare_county, name='compare_county'),
)
