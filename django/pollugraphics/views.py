from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.template import RequestContext, loader
from pollugraphics.models import County, State, Facility, FacilityPollution

def index(request):
	#return HttpResponseRedirect("Hello world.")
	counties = County.objects.all()
	template = loader.get_template('pollugraphics/index.html')
	context = RequestContext(request, {
		'counties' : counties,
	})
	return HttpResponse(template.render(context))

def county(request, county_name):
	return HttpResponse(county_name)

def facility(request, facility_id):
	return HttpResponse(facility_id)
