import math

def convertIntoCoordinates(coordinates):
    """

    :param coordinates: [(degrees, minutes, seconds), (degrees, minutes, seconds)] lat and long coodinates
    :return: float coorindates of the coordinates
    """
    latitude = coordinates[0]
    longitude = coordinates[1]

    latitude = latitude[0] + float(latitude[1])/60 + float(latitude[2])/3600
    longitude = longitude[0] + float(longitude[1])/60 + float(longitude[2])/3600

    return latitude, longitude


class BoundingBox( object ):
   def __init__(self, *args, **kwargs):
       self.lat_min = None
       self.lon_min = None
       self.lat_max = None
       self.lon_max = None


def get_bounding_box(latitude_in_degrees, longitude_in_degrees, half_side_in_miles):
   assert half_side_in_miles > 0
   assert latitude_in_degrees >= -90.0 and latitude_in_degrees <= 90.0
   assert longitude_in_degrees >= -180.0 and longitude_in_degrees <= 180.0

   half_side_in_km = half_side_in_miles * 1.609344
   lat = math.radians( latitude_in_degrees )
   lon = math.radians( longitude_in_degrees )

   radius = 6371
   # Radius of the parallel at given latitude
   parallel_radius = radius * math.cos( lat )

   lat_min = lat - half_side_in_km / radius
   lat_max = lat + half_side_in_km / radius
   lon_min = lon - half_side_in_km / parallel_radius
   lon_max = lon + half_side_in_km / parallel_radius
   rad2deg = math.degrees

   box = BoundingBox( )
   box.lat_min = rad2deg( lat_min )
   box.lon_min = rad2deg( lon_min )
   box.lat_max = rad2deg( lat_max )
   box.lon_max = rad2deg( lon_max )

   return (box)

if __name__ == "__main__":
    latitude, longitude = convertIntoCoordinates([(40, 52, 47), (73, 55, 22)])
    print latitude 
    print longitude
    boundingBox = get_bounding_box(latitude, longitude, 2.5)
    print boundingBox.lat_min
    print boundingBox.lat_max
    print boundingBox.lon_min
    print boundingBox.lon_max

