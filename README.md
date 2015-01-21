A simple MirageOS application providing a simple webservice returning random quotations from Kaamelott (http://en.wikipedia.org/wiki/Kaamelott).

Mostly based on the examples in https://github.com/mirage/mirage-skeleton

Quotations are extracted from https://aur.archlinux.org/packages/fortune-mod-kaamelott/ and located in htdocs/.

Build instructions, stolen from mirage-skeleton repository

```
$ env NET=socket FS=crunch mirage configure --unix
$ make depend
$ make
$ make run
```

For a Xen DHCP kernel, do:

```
$ env DHCP=true mirage configure --xen
$ make
$ make run
```

edit `www.xl` to add a VIF, e.g. via:

```
vif = ['bridge=xenbr0']
```

And then run the VM via `xl create -c www.xl`

Example quotation:
```

{
  quote: "Ca s'enferme les registres ! (Glaucia : Ah bon ? ) Ouais ! Et les trous du cul qui font pas leur boulot ça s'enferme aussi ! ",
  meta: "Capito, Livre VI, 1 : Miles Ignotus"
}

```
