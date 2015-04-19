# FX App
### Cat Burston, 2015
This is a simple Foreign Exchange converter using data supplied by the [European Central Bank](http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml)

## How to run the FX App
The app runs on Sinatra, powered by Ruby and uses the Nokogiri gem to parse the ECB xml data.

Launch the app locally by cloning the project then running the command 'rackup' in Terminal from the app directory

Open [http://localhost:9292/](http://localhost:9292/) in your browser and start converting currencies to the Euro.
