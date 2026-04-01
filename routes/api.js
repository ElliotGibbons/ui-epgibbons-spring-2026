const express = require('express');
const router = express.Router();

router.get('/travel-time', async (req, res) => {
    try
    {
        const origin = req.query.origin;
        const destination = req.query.destination;
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
        const url = `https://maps.googleapis.com/maps/api/distancematrix/json` +
        `?origins=${encodeURIComponent(origin)}` +
        `&destinations=${encodeURIComponent(destination)}` +
        `&key=${apiKey}`;

        const response = await fetch(url);
        const data = await response.json();

        if(data.status !== 'OK')
        {
            return res.status(400).json({
                error: 'Google API request failed',
                googleStatus: data.status
            });
        }

        const element = data?.rows?.[0]?.elements?.[0];

        if(!element || element.status !== 'OK') {
            return res.status(400).json({
                error: 'Could not calculate travel time',
                googleStatus: element?.status || 'UNKNOWN'
            });
        }
        
        return res.json({
            origin: data.origin_addresses?.[0] ?? origin,
            destination: data.destination_addresses?.[0] ?? destination,
            distanceText: element.distance?.text ?? null,
            distanceValue: element.distance?.value ?? null,
            durationText: element.duration?.text ?? null,
            durationValue: element.duration?.value ?? null
        });
    } 
    catch (error){
        console.error('travel-time route error:', error.message);
        return res.status(500).json({
        error: 'Internal server error'
        });
    }
    
});

module.exports = router;