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

        console.log('Request URL:', url);

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

router.get('/ping', (req, res) => {
    res.json({message: 'API is running'});
});

module.exports = router;