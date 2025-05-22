{# combine yellow and green taxi data and encase with locationid fromm zones data #}

{# models should be more performant closer we are to bi,
 queries will be more effecient and also more performant
 so stackholders don't complain about speed#}

{{
    config(
        materialized='table'
    )
}}

with green_tripdata as(
    select *,
        'Green' as service_type
    from {{ ref('stg_green_trip_data') }}
),

yellow_tripdata as(
    select *,
        'Yellow' as service_type
    from {{ ref('stg_yellow_trip_data') }}
),

trips_unioned as(
    select * from green_tripdata
    union all
    select * from yellow_tripdata
),

dim_zones as(
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select 
    trips_unioned.tripid, 
    trips_unioned.vendorid, 
    trips_unioned.service_type,
    trips_unioned.ratecodeid, 
    trips_unioned.pickup_locationid, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    trips_unioned.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    trips_unioned.pickup_datetime, 
    trips_unioned.dropoff_datetime, 
    trips_unioned.store_and_fwd_flag, 
    trips_unioned.passenger_count, 
    trips_unioned.trip_distance, 
    trips_unioned.trip_type, 
    trips_unioned.fare_amount, 
    trips_unioned.extra, 
    trips_unioned.mta_tax, 
    trips_unioned.tip_amount, 
    trips_unioned.tolls_amount, 
    trips_unioned.ehail_fee, 
    trips_unioned.improvement_surcharge, 
    trips_unioned.total_amount, 
    trips_unioned.payment_type, 
    trips_unioned.payment_type_description
from trips_unioned
inner join dim_zones as pickup_zone
on trips_unioned.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on trips_unioned.dropoff_locationid = dropoff_zone.locationid

-- since pickup_zones and drop_off_zone come fomr the same table, we must use aliases for the columns to prevent columns with
-- the same names.
