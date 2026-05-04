const express = require('express');
const router = express.Router();

router.get('/travel-time', async (req, res) => {
    try
    {
        const { origin, destination, departureTime } = req.query;
        const apiKey = process.env.GOOGLE_MAPS_API_KEY;

        if (!origin || !destination) 
        {
            return res.status(400).json({ 
                error: 'origin and destination are required' 
            });
        }

        if(!apiKey)
        {
            return res.status(500).json({
                error: 'Missing Google maps api key'
            });
        }
        
        const body = {
            origin: {
                address: origin
            },
            destination: {
                address: destination
            },
            travelMode: 'DRIVE',
            routingPreference: 'TRAFFIC_AWARE_OPTIMAL'
        };

        if(departureTime)
        {
            body.departureTime = departureTime;
        }

        //console.log('Request URL:', url);

        const response = await fetch(
            'https://routes.googleapis.com/directions/v2:computeRoutes',
            {
                method: 'POST',
                headers: {
                'Content-Type': 'application/json',
                'X-Goog-Api-Key': apiKey,
                'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters'
                },
                body: JSON.stringify(body)
            }
        );

        const rawText = await response.text();

        if(!response.ok)
        {
            return res.status(502).json({
                error: 'Failed to reach Routes API',
                httpStatus: response.status,
                details: rawText
            });
        }

        const data = JSON.parse(rawText);
        const route = data.routes?.[0];

        if(!route)
        {
            return res.status(400).json({
                error: 'No route returned',
                details: data
            });
        }

        return res.json({
            origin,
            destination,
            departureTime: departureTime || null,
            duration: route.duration,
            distanceMeters: route.distanceMeters
        });
    } 
    catch (error){
        console.error('travel-time route error:', error);
        return res.status(500).json({
        error: 'Internal server error'
        });
    }
    
});

router.get('/best-departure-time', async (req, res) => {
    try {
        const { origin, destination, date, tzOffset } = req.query;
        const apiKey = process.env.GOOGLE_MAPS_API_KEY;

        if (!origin || !destination || !date) {
            return res.status(400).json({
                error: 'origin, destination, and date are required'
            });
        }

        if (!apiKey) {
            return res.status(500).json({
                error: 'Missing Google Maps API key'
            });
        }

        const offset = tzOffset || '-06:00';

        const departureHours = [
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23
        ];

        const results = [];

        for (const hour of departureHours) {
            const hourString = hour.toString().padStart(2, '0');
            const departureTime = `${date}T${hourString}:00:00${offset}`;

            const body = {
                origin: {
                    address: origin
                },
                destination: {
                    address: destination
                },
                travelMode: 'DRIVE',
                routingPreference: 'TRAFFIC_AWARE_OPTIMAL',
                departureTime
            };

            const response = await fetch(
                'https://routes.googleapis.com/directions/v2:computeRoutes',
                {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Goog-Api-Key': apiKey,
                        'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters'
                    },
                    body: JSON.stringify(body)
                }
            );

            const rawText = await response.text();

            if (!response.ok) {
                console.log('Routes API status:', response.status);
                console.log('Routes API error:', rawText);

                return res.status(502).json({
                    error: 'Failed to reach Routes API',
                    httpStatus: response.status,
                    details: rawText
                });
            }

            const data = JSON.parse(rawText);
            const route = data.routes?.[0];

            if (!route) {
                continue;
            }

            const durationSeconds = parseInt(
                route.duration.replace('s', ''),
                10
            );

            const arrivalDate = new Date(new Date(departureTime).getTime() + durationSeconds * 1000);

            results.push({
                departureLabel: formatHourLabel(hour),
                departureTime,
                arrivalTime: arrivalDate.toISOString(),
                arrivalLabel: formatTimeLabel(arrivalDate),
                durationText: formatDuration(durationSeconds),
                durationSeconds,
                distanceMeters: route.distanceMeters
            });
        }

        if (results.length === 0) {
            return res.status(400).json({
                error: 'No routes returned'
            });
        }

        results.sort((a, b) => a.durationSeconds - b.durationSeconds);

        const best = results[0];

        return res.json({
            bestDepartureLabel: best.departureLabel,
            bestDuration: best.durationText,
            bestDepartureTime: best.departureTime,
            bestArrivalLabel: best.arrivalLabel,
            bestArrivalTime: best.arrivalTime,
            results
        });

    } catch (error) {
        console.error('best-departure-time route error:', error);
        return res.status(500).json({
            error: 'Internal server error'
        });
    }
});

router.get('/ping', (req, res) => {
    res.json({message: 'API is running'});
});

function formatDuration(seconds) {
    if (!Number.isFinite(seconds)) {
        return 'Unknown duration';
    }

    const hours = Math.floor(seconds / 3600);
    const minutes = Math.round((seconds % 3600) / 60);

    if (hours === 0) {
        return `${minutes} min`;
    }

    if (minutes === 0) {
        return `${hours} hr`;
    }

    return `${hours} hr ${minutes} min`;
}

function formatHourLabel(hour) {
    const period = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 === 0 ? 12 : hour % 12;

    return `${displayHour} ${period}`;
}

function formatTimeLabel(date) {
    let hours = date.getHours();
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const period = hours >= 12 ? 'PM' : 'AM';

    hours = hours % 12;
    hours = hours === 0 ? 12 : hours;

    return `${hours}:${minutes} ${period}`;
}

module.exports = router;