from django.conf.urls import patterns, url
from pollugraphics import views

urlpatterns = patterns('',
	url(r'^$', views.index, name='index'),
	url(r'^county/(?P<county_id>\d+)/$', views.county, name='county'),
	url(r'^facility/(?P<facility_id>\d+)/$', views.facility, name='facility'),
        # the following patterns are for facility views of each county
        url(r'^county/(?P<county_id>\d+)/(?P<pollutant>\w+)/$', views.countyPollution, name='countyPollution')
)
