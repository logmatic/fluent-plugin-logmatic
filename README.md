# Fluentd output plugin for Logmatic.io.
Link to the [Logmatic.io documentation](http://doc.logmatic.io/docs/using-fluentd)*


It mainly contains a proper JSON formatter and a socket handler that
streams logs directly to Logmatic.io - so no need to use a log shipper
if you don't wan't to.

## Pre-requirements

To add the plugin to your fluentd agent, use the following command:

    gem install fluent-plugin-logmatic

## Usage
### Configure the output plugin

To match events and send them to logmatic.io, simply add the following code to your configuration file.

```xml
# Match events tagged with "logmatic.**" and
# send them to Logmatic.io
<match logmatic.**>

  @type logmatic
  @id awesome_agent
  
  api_key <your_api_key>


</match>

```

After a restart of FluentD, any child events tagged with `logmatic` are shipped to your plateform.

### Validation
Let's make a simple test.

```bash
echo '{"message":"hello Logmatic from fluentd"}' | fluent-cat logmatic.demo
```

Produces the following event:

```javascript
{ 
    "custom": {
        "message": "hello Logmatic from fluentd"
     }
}
```

### fluent-plugin-logmatic properties
Let's go deeper on the plugin configuration.

As fluent-plugin-logmatic is an output_buffer, you can set all output_buffer properties like it's describe in the [fluentd documentation](http://docs.fluentd.org/articles/output-plugin-overview#buffered-output-parameters "documentation").


|  Property   |  Description                                                             |  Default value |
|-------------|--------------------------------------------------------------------------|----------------|
| **api_key** | This parameter is required in order to authenticate your fluent agent.   | nil            |
| **use_json**| Event format, if true, the event is sent in json format. Othwerwise, in plain text. | true      |
| **include_tag_key**| Automatically include tags in the record. | false      |
| **tag_key**| Name of the tag attribute, if they are included. | "tag"      |
| **use_ssl** | If true, the agent initializes a secure connection to Logmatic.io. In clear TCP otherwise. | true |
|**max_retries**| The number of retries before the output plugin stops. Set to -1 for unlimited retries | -1 |
