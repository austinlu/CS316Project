from django.db import models

class State(models.Model):
	abbreviation = models.CharField(max_length=2, primary_key=True)
	name = models.CharField(max_length=20)

	class Meta:
		db_table = 'state'

	def __unicode__(self):
		return self.abbreviation

class County(models.Model):
	name = models.CharField(max_length=50)
	state = models.ForeignKey(State)
	population_density = models.DecimalField(decimal_places=2, max_digits=20)
	unemployment_rate = models.DecimalField(decimal_places=2, max_digits=20)
	median_income = models.DecimalField(decimal_places=2, max_digits=20)
	percent_hs = models.DecimalField(decimal_places=2, max_digits=20)
	percent_bachelors = models.DecimalField(decimal_places=2, max_digits=20)

	class Meta:
		db_table = 'county'
	
	def __unicode__(self):
		return self.name + ' County (' + self.state.name + ')'

class Facility(models.Model):
	eis_id = models.IntegerField(primary_key=True)
	name = models.CharField(max_length=200)
	address = models.CharField(max_length=200, null=True, blank=True)
	city = models.CharField(max_length=200, null=True, blank=True)
	county = models.CharField(max_length=50)
	state = models.ForeignKey(State)
	industry = models.CharField(max_length=200, null=True, blank=True)
	latitude = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)
	longitude = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)

	class Meta:
		db_table = 'facility'
	
	def __unicode__(self):
		return self.name

class FacilityPollution(models.Model):
	eis_id = models.ForeignKey(Facility, primary_key=True)
	carbon_monoxide = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)
	nitrogen_oxides = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)
	sulfur_dioxide = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)
	particulate_matter_10 = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)
	lead = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)
	mercury = models.DecimalField(decimal_places=10, max_digits=20, null=True, blank=True)

	class Meta:
		db_table = 'facilitypollution'


