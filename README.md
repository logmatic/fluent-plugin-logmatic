fluent-plugin-logmatic
===============

Fluentd output plugin for Logmatic.io.

It mainly contains a proper JSON formatter and a socket handler that
streams logs directly to Logmatic.io - so no need to use a log shipper
if you don't wan't to.

Pre-requirements
================

To add the plugin to your fluentd agent, use the following command:

    gem install fluent-plugin-logmatic

Usage
=====

"match" Tell fluentd how to send to Logmatic.io
--------------------------

To match events tagged logmatic, simply add the following code to your configuration file.

```xml
# Match events tagged with "logmatic.**" and
# send them to Logmatic.io
<match logmatic.**>

  @type logmatic
  @id awesome_agent
  
  api_key <your_api_key>

</match>

```

Once this setup is done, any child events tagged with `logmatic` will be ship to your plateform.

Let's make a simple test.

```bash
echo '{"message":"hello world from fluentd"}' | fluent-cat logmatic.demo
```

This will produce the following event:

```javascript
{ 
	"custom": {
    	"message": "hello world from fluentd" 
     }
}
```

fluent-plugin-logmatic properties
======
Let's go deeper on the plugin configuration. 

As fluent-plugin-logmatic is an output_buffer, you can set all output_buffer properties like it's describe in the [fluentd documentation](http://docs.fluentd.org/articles/output-plugin-overview#buffered-output-parameters "documentation").

api_key
--------
This parameter is required in order to authenticate your fluent agent. The agent won't started until set your key.    

use_json 
--------
If it's set to true, the event will be send to json format. If it's set to false, only the key `message` of the record will be sent to Logmatic.io. Set to true by default.

use_ssl
--------
If it's set to true, the agent initialize a secure connection to Logmatic. Set to true by default. 


max_retries
--------
The number of retries before raised an error. By default, this parameter is set to 3.


