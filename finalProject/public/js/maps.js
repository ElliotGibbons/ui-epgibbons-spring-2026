/*function initMap() {
    const location = { lat: 39.7392, lng: -104.9903 }; // Denver

    const map = new google.maps.Map(document.getElementById("map"), {
      zoom: 12,
      center: location,
    });

    new google.maps.Marker({
      position: location,
      map: map,
    });*/

fetch('/api/travel-time?origin=Grand+Junction&destination=Denver')
  .then(res => res.json())
  .then(data => console.log(data))