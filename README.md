# FoodBite8 MVP

Flutter MVP for food-event discovery in Berlin, Vienna and Amsterdam.

## Run locally
1. Install Flutter stable.
2. In this folder run:

   flutter pub get
   flutter run

## Included

- Discover feed with city and type filters.
- Calendar overview.
- Interactive schematic map without external API keys.
- Event details with verified state, price, route and registration information.
- Saved events and reminder state.

## Next integration steps

1. Replace the in-memory list in lib/main.dart with Supabase/PostgreSQL.
2. Add Mapbox or Google Maps with the relevant platform API keys.
3. Connect authentication, notification permissions and deep links.
4. Add server-side moderation and data-import services.
