from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.template import RequestContext, loader
from django.core.urlresolvers import reverse
from pollugraphics.models import County, State, Facility, FacilityPollution

def index(request):
	counties = County.objects.all()
	states = State.objects.order_by('abbreviation')
	template = loader.get_template('pollugraphics/index.html')
	context = RequestContext(request, {
		'counties' : counties,
		'states' : states,
	})
	return HttpResponse(template.render(context))

def county(request, county_id):
	print request
	c = get_object_or_404(County, pk=county_id)
	return render(request, 'pollugraphics/county.html', {
		'county': c,
		'comps': County.objects.raw('SELECT id,name FROM County ORDER BY abs((select unemployment_rate from County where id = %s) - unemployment_rate) limit 3', [county_id])
	   # 'comps':Comps.objects.raw('SELECT name FROM County' )

	})
#	return HttpResponseRedirect(reverse('county', args=(), 
#		kwargs={'county': c}))

def facility(request, facility_id):
	return HttpResponse(facility_id)
