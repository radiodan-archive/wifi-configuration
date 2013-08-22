# WpaCliWeb

This gem provides a web interface for configuring Wifi connections on
systems that include the `wpa_cli` command line interface to the
`wpa_supplicant` tool. It was written to allow configuration of the
Wifi on a Raspberry Pi when a keyboard and monitor is difficult to
connect (in embedded applications for example).

## Installation

    $ gem install wpa_cli_web

## Usage

    $ wpa_cli_web start

This will start the web interface on the default port 3000. Run
`wpa_cli_web -h` for further options.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
