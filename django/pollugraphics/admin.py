from django.contrib import admin
from pollugraphics.models import County, State, Facility, FacilityPollution

admin.site.register(County)
admin.site.register(State)
admin.site.register(Facility)
admin.site.register(FacilityPollution)
