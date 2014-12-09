# nginx-config-cookbook [![Build Status](https://travis-ci.org/pmsipilot/nginx-config-cookbook.svg?branch=master)](https://travis-ci.org/pmsipilot/nginx-config-cookbook)

Configures nginx

## Supported Platforms

* CentOS 6.5

## Attributes

| Key         | Type       | Default | Description                                           |
| :---------- |:---------- | :------ | :---------------------------------------------------- |
| `servers`   | Hash       | `{}`    | A list of servers with names as key                   |

### Servers

| Key         | Type       | Default | Description                                           |
| :---------- |:---------- | :------ | :---------------------------------------------------- |
| `port`      | Integer    | `80`    | The port to listen on                                 |
| `root`      | String     | `nil`   | The server's document root                            |
| `enable`    | Boolean    | `true`  | Enable or disable the server                          |
| `upstreams` | Hash       | `{}`    | A list of [upstreams](#upstreams) with names as key   |
| `locations` | Array      | `[]`    | A list of [locations](#locations) definitions         |

### Upstreams

| Key         | Type       | Default | Description                                           |
| :---------- |:---------- | :------ | :---------------------------------------------------- |
| `ip`        | String     | `nil`   | The IP of the upstream server                         |
| `port`      | Integer    | `80`    | The port of the upstream server                       |

### Locations

| Key         | Type       | Default | Description                                           |
| :---------- |:---------- | :------ | :---------------------------------------------------- |
| `path`      | String     | `nil`   | The location path                                     |
| `alias`     | String     | `nil`   | The location alias                                    |
| `upstream`  | String     | `nil`   | Name of an existing [upstream](#upstreams)            |

## Usage

### nginx-config::default

Include `nginx-config` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[nginx-config]"
  ]
}
```

### nginx-config::clean

This recipe will let you disable server configurations. Every server marked with `enable => false`
will be disabled (i.e. configuration file or symlink deleted):

```json
{
  "run_list": [
    "recipe[nginx-config]",
    "recipe[nginx-config::clean]"
  ]
}
```
