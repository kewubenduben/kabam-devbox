# Kabam-app Devbox Repository

Currently we use Puppetlabs Puppet for our orchestration.

* We use puppet for deployment

## Install pre-requisites

* [vagrant](http://www.vagrantup.com/) v1.6.3; _Create and configure lightweight, reproducible, and portable development environments._
* [virtualbox](https://www.virtualbox.org/) v4.3.14

## Download kabam-puppet modules

```bash
git clone git@github.com:mykabam/kabam-puppet.git
```

## Download showdme source

```bash
git clone git@github.com:mykabam/showdme.git
```

## Create box, provisions on first up

```bash
vagrant up
```

## To be able to ssh to the box

```bash
vagrant ssh
```


---

### Additional notes

```
This also removes the need to have puppet master access-grant
a bit of todo will be
1. initial mongodb db load[dump, restore]
2. npm runs
3. Add more docs on how to develop
4. Simplify
```
