from django.db import models

class State(models.Model):
	name = models.CharField(max_length=20)
	abbreviation = models.CharField(max_length=2)

	def __unicode__(self):
		return self.abbreviation

class County(models.Model):
	state = models.ForeignKey(State)
	name = models.CharField(max_length=20)
	
	def __unicode__(self):
		return name + ' (' + state + ')'
