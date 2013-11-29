from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.template import RequestContext, loader
from django.core.urlresolvers import reverse
from pollugraphics.models import County, State, Facility, FacilityPollution, CountyAttributesForm
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
	if request.is_ajax():
		if request.GET.get('action') == 'compare':
			comps = County.objects.raw('SELECT id, name FROM County LIMIT 5')
			json = simplejson.dumps(comps, cls=DjangoJSONEncoder)
			return HttpResponse(json, mimetype='application/json')
	
	c = get_object_or_404(County, pk=county_id)
	cursor = connection.cursor()
	cursor.execute('SELECT sum(carbon_monoxide), sum(nitrogen_oxides), sum(sulfur_dioxide), sum(particulate_matter_10), sum(lead), sum(mercury), count(*), count(carbon_monoxide),count(nitrogen_oxides), count(sulfur_dioxide), count(particulate_matter_10), count(lead), count(mercury) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])
	row = cursor.fetchone()

	return render(request, 'pollugraphics/county.html', {
		'county': c,
		'aggPollution': row,
		'form': CountyAttributesForm(request.POST)
		})

def compare(request, county_id1, county_id2):
	c1 = get_object_or_404(County, pk=county_id1)
	c2 = get_object_or_404(County, pk=county_id2)
	cursor = connection.cursor()
	cursor.execute('SELECT sum(carbon_monoxide), sum(nitrogen_oxides), sum(sulfur_dioxide), sum(particulate_matter_10), sum(lead), sum(mercury), count(*), count(carbon_monoxide),count(nitrogen_oxides), count(sulfur_dioxide), count(particulate_matter_10), count(lead), count(mercury) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id1])
	row1 = cursor.fetchone()
	cursor.execute('SELECT sum(carbon_monoxide), sum(nitrogen_oxides), sum(sulfur_dioxide), sum(particulate_matter_10), sum(lead), sum(mercury), count(*), count(carbon_monoxide),count(nitrogen_oxides), count(sulfur_dioxide), count(particulate_matter_10), count(lead), count(mercury) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id2])
	row2 = cursor.fetchone()

	return render(request, 'pollugraphics/compare.html', {
		'county1': c1,
		'county2': c2,
		'aggPollution1': row1,
		'aggPollution2': row2
		})
		
def compare_county(request, county_id, limit=5):
	c = get_object_or_404(County, pk=county_id)
	same_state = request.GET.get('state', '')
	sort_by = request.GET.get('sort', '')

	if same_state == 'yes':
		comps = County.objects.raw('SELECT * FROM County WHERE state_id = \'%s\' AND id != %s ORDER BY abs((SELECT %s FROM County WHERE id = %s) - %s) LIMIT %d;' % (c.state, c.id, sort_by, county_id, sort_by, limit))
	else:
		comps = County.objects.raw('SELECT * FROM County WHERE id != %s ORDER BY abs((SELECT %s FROM County WHERE id = %s) - %s) LIMIT %d;' % (c.id, sort_by, county_id, sort_by, limit))
		
	return render(request, 'pollugraphics/similar_counties.html', {
		'county': c,
		'comps': comps,
		})
	
def facility(request, facility_id):
	f = get_object_or_404(Facility, pk=facility_id)
	fp = get_object_or_404(FacilityPollution, pk=facility_id)
	return render(request, 'pollugraphics/facility.html', {
		'facility': f,
		'facilitypollution': fp
		})

def countyPollution(request, county_id, pollutant):
	c = get_object_or_404(County, pk=county_id)
	if pollutant=='CO':
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.address, Facility.city, FacilityPollution.carbon_monoxide AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.carbon_monoxide>0 ORDER BY FacilityPollution.carbon_monoxide DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant
	        })
	elif pollutant=='NOx':
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.address, Facility.city, FacilityPollution.nitrogen_oxides AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.nitrogen_oxides>0 ORDER BY FacilityPollution.nitrogen_oxides DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant
	        })
	elif pollutant=='SO2':
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.address, Facility.city, FacilityPollution.sulfur_dioxide AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.sulfur_dioxide>0 ORDER BY FacilityPollution.sulfur_dioxide DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant
	        })
	elif pollutant=='PM10':
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.address, Facility.city, FacilityPollution.particulate_matter_10 AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.particulate_matter_10>0 ORDER BY FacilityPollution.particulate_matter_10 DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant
	        })
	elif pollutant=='lead':
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.address, Facility.city, FacilityPollution.lead AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.lead>0 ORDER BY FacilityPollution.lead DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant
	        })
	elif pollutant=='mercury':
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.address, Facility.city, FacilityPollution.mercury AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.mercury>0 ORDER BY FacilityPollution.mercury DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant
	        })
	return HttpResponse(facility_id)