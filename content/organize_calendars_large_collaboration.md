Title: Organize calendars for a large scientific collaboration
Date: 2019-12-02 12:00
Author: Andrea Zonca
Tags: google-calendar
Slug: organize-calendar-collaboration

Many scientific collaborations have a central calendar, often hosted on Google Calendar,
to coordinate Teleconferences, meetings and events across timezones.

### The issue

Most users are only interested in a small subset of the events, however Google Calendar
does not allow them to subscribe to single events. The central calendar admin could invite
each person to events, but that requires lots of work.

So, users either subscribe to the whole calendar, but then have a huge clutter of un-interesting events,
or copy just a subset of the events to their calendars, but loose track of any rescheduling of the
original event.

### Proposed solution

I recommend to split the events across multiple calendars, for example one for each working group,
or any other categorization where most users would be interested in all events in a calendar.
And possibly a "General" category with events that should interest the whole collaboration.

Still, we can embed all of the calendars in a single webpage, see an example below where 2 calendars (Monday and Tuesday telecon calendars) are visualized together, [see the Google Calendar documentation](https://support.google.com/calendar/answer/41207?hl=en).

<iframe src="https://calendar.google.com/calendar/embed?height=600&amp;wkst=1&amp;bgcolor=%23ffffff&amp;ctz=America%2FLos_Angeles&amp;src=dTI2dnBkNnZvcm1qNHVucnVtajMzZzdwcGNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&amp;src=c2FwazM1OTVmcHRiZHVtOWdqZnJwdWxkbnNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&amp;color=%23DD4477&amp;color=%236633CC" style="border-width:0" width="800" height="600" frameborder="0" scrolling="no"></iframe>

Users can click on the bottom "Add to Google Calendar" button and subscribe to a subset or all the calendars.
See the screenshot below, ![screenshot of add to Google Calendar](/images/add_google_calendar.png).

As an additional benefit, we can compartimentalize permissions more easily, e.g. leads of a working group
get writing access only to their relevant calendar/calendars.
