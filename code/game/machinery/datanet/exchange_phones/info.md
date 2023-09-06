Based around a similar state machine, these phones are slaved to 'exchanges' which exist in a department's substation

Due to the fact that substations segment the powernet, phones are unable to directly connect with each other, and must bounce between exchanges

Phone numbers use letter-prefix dialing, both as a joke, and because it actually works.

SUP-SEC-MED-ENG-SCI-COM-SRV
787-732-633-364-724-266-778

Protocol:

trunk_seize
	trunk_id - combination of originating office code, and active call number, "555-1"
	d_number - final number, still with exchange code, "555 1234"
	caller_id - Caller ID string, "Medical office", etc.
