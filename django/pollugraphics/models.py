from django.db import models

class State(models.Model):
	abbreviation = models.CharField(max_length=2, primary_key=True)
	name = models.CharField(max_length=20)

	class Meta:
		db_table = 'state'

	def __unicode__(self):
		return self.abbreviation

class County(models.Model):
	state = models.ForeignKey(State)
	name = models.CharField(max_length=50)
	population_density = models.DecimalField(decimal_places=10, max_digits=20)
	unemployment_rate = models.DecimalField(decimal_places=10, max_digits=20)
	median_income = models.DecimalField(decimal_places=10, max_digits=20)
	percent_hs = models.DecimalField(decimal_places=10, max_digits=20)
	percent_bachelors = models.DecimalField(decimal_places=10, max_digits=20)

	class Meta:
		db_table = 'county'
	
	def __unicode__(self):
		return self.name + ' County (' + self.state.name + ')'

class Facility(models.Model):
	eis_id = models.IntegerField(primary_key=True)
	name = models.CharField(max_length=50)
	address = models.CharField(max_length=200)
	city = models.CharField(max_length=50)
	county = models.ForeignKey(County)
	state = models.ForeignKey(State)
	industry = models.CharField(max_length=200)
	latitude = models.DecimalField(decimal_places=10, max_digits=20)
	longitude = models.DecimalField(decimal_places=10, max_digits=20)

	class Meta:
		db_table = 'facility'
	
	def __unicode__(self):
		return self.name

class FacilityPollution(models.Model):
	eis_id = models.ForeignKey(Facility)
	carbon_monoxide = models.DecimalField(decimal_places=10, max_digits=20)
	nitrogen_oxides = models.DecimalField(decimal_places=10, max_digits=20)
	sulfur_dioxide = models.DecimalField(decimal_places=10, max_digits=20)
	particulate_matter_10 = models.DecimalField(decimal_places=10, max_digits=20)
	lead = models.DecimalField(decimal_places=10, max_digits=20)
	mercury = models.DecimalField(decimal_places=10, max_digits=20)

	class Meta:
		db_table = 'facilitypollution'


