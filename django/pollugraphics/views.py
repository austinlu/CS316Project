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

def facility_search(request):
	return render(request, 'facility_search.html')

def search(request):
	error = False
	if "facilityChoice" in request.GET:
		facilityChoice = request.GET['facilityChoice']
		if not facilityChoice:
			error = True
		else:
			facility = Facility.objects.filter(name__icontains=facilityChoice)
			return render(request, 'pollugraphics/facility_search.html',
				      {'facilities': facility, 'query': facilityChoice})
	return render(request, 'pollugraphics/facility_search.html', {'error': True})

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
	if(row is None):
		row = tuple([0]*13)
	else:
		row = tuple((x if x is not None else 0 for x in row))

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
	row1 = cursor.fetchone();
	if(row1 is None):
		row1 = tuple([0]*13)
	else:
		row1 = tuple((x if x is not None else 0 for x in row1))

	cursor.execute('SELECT sum(carbon_monoxide), sum(nitrogen_oxides), sum(sulfur_dioxide), sum(particulate_matter_10), sum(lead), sum(mercury), count(*), count(carbon_monoxide),count(nitrogen_oxides), count(sulfur_dioxide), count(particulate_matter_10), count(lead), count(mercury) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id2])
	row2 = cursor.fetchone();
	if(row2 is None):
		row2 = tuple([0]*13)
	else:
		row2 = tuple((x if x is not None else 0 for x in row2))

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
	cursor = connection.cursor()
	if pollutant=='CO':
		cursor.execute('SELECT sum(carbon_monoxide), count(carbon_monoxide) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.city, FacilityPollution.carbon_monoxide AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.carbon_monoxide>0 ORDER BY FacilityPollution.carbon_monoxide DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant,
		   'aggPollutant': cursor.fetchone()
	        })
	elif pollutant=='NOx':
		cursor.execute('SELECT sum(nitrogen_oxides), count(nitrogen_oxides) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])	
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.city, FacilityPollution.nitrogen_oxides AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.nitrogen_oxides>0 ORDER BY FacilityPollution.nitrogen_oxides DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant,
		   'aggPollutant': cursor.fetchone()
	        })
	elif pollutant=='SO2':
		cursor.execute('SELECT sum(sulfur_dioxide), count(sulfur_dioxide) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])	
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.city, FacilityPollution.sulfur_dioxide AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.sulfur_dioxide>0 ORDER BY FacilityPollution.sulfur_dioxide DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant,
		   'aggPollutant': cursor.fetchone()
	        })
	elif pollutant=='PM10':
		cursor.execute('SELECT sum(particulate_matter_10), count(particulate_matter_10) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])		
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.city, FacilityPollution.particulate_matter_10 AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.particulate_matter_10>0 ORDER BY FacilityPollution.particulate_matter_10 DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant,
		   'aggPollutant': cursor.fetchone()
	        })
	elif pollutant=='lead':
		cursor.execute('SELECT sum(lead), count(lead) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])		
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.city, FacilityPollution.lead AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.lead>0 ORDER BY FacilityPollution.lead DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant,
		   'aggPollutant': cursor.fetchone()
	        })
	elif pollutant=='mercury':
		cursor.execute('SELECT sum(mercury), count(mercury) FROM County, Facility, FacilityPollution WHERE County.id = %s AND County.name = Facility.county AND County.state_id = Facility.state_id AND Facility.eis_id = FacilityPollution.eis_id_id GROUP BY County.name;',[county_id])			
		return render(request, 'pollugraphics/pollutant.html',{
	       'polluters': Facility.objects.raw('SELECT Facility.eis_id, Facility.name, Facility.city, FacilityPollution.mercury AS pollute FROM County, Facility, FacilityPollution WHERE Facility.eis_id = FacilityPollution.eis_id_id AND Facility.county=County.name AND Facility.state_id=County.state_id AND County.id=%s AND FacilityPollution.mercury>0 ORDER BY FacilityPollution.mercury DESC LIMIT 10;', [county_id]),
	       'county': c,
	       'pollutant': pollutant,
		   'aggPollutant': cursor.fetchone()
	        })
	return HttpResponse(facility_id)
