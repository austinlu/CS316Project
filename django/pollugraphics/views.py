from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.template import RequestContext, loader
from django.core.urlresolvers import reverse
from pollugraphics.models import County, State, Facility, FacilityPollution
from django.db import connection

def index(request):
	counties = County.objects.order_by('state__name', 'name')
	states = State.objects.order_by('abbreviation')
	template = loader.get_template('pollugraphics/index.html')
	context = RequestContext(request, {
		'counties' : counties,
		'states' : states,
	})
	return HttpResponse(template.render(context))

def county(request, county_id):
	c = get_object_or_404(County, pk=county_id)
	cursor = connection.cursor()
	cursor.execute('SELECT sum(carbon_monoxide), sum(nitrogen_oxides), sum(sulfur_dioxide), sum(particulate_matter_10), sum(lead), sum(mercury), count(*) FROM FacilityPollution where eis_id_id in (select eis_id from Facility where county = (select name from county where county.id = %s) );', [county_id])
	row = cursor.fetchone()

	return render(request, 'pollugraphics/county.html', {
		'county': c,
		'comps': County.objects.raw('SELECT id,name FROM County ORDER BY abs((select unemployment_rate from County where id = %s) - unemployment_rate) limit 3', [county_id]),
		'aggPollution': row
		})
	
def facility(request, facility_id):
	return HttpResponse(facility_id)
