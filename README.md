# robles

> [Ángela Ruiz Robles](https://en.wikipedia.org/wiki/Ángela_Ruiz_Robles) (March 28, 1895 Villamanín,
> Leon - October 27, 1975, Ferrol, A Coruña) was a Spanish teacher, writer, pioneer and inventor of
> the mechanical precursor to the electronic book. In 1949, Ruiz was awarded Spanish patent 190,698
> for the "Mechanical Encyclopedia".

__robles__ is a tool that can build Kodeco books and video courses from their git repositories,\
and publish them to [`alexandria`](https://github.com/razeware/alexandria) and
[`betamax`](https://github.com/razeware/betamax) respectively..

## Usage

__robles__ is built into a Docker container, containing all relevant dependencies. This is designed
to work in both CI and local environments.

To build the container:

```
$ docker build -t robles .
```

The docker container expects the book or video repository to be mounted to `/data/src` inside the container.
To publish a book to `alexandria` or a video course to `betamax`, ensure that you've populated the `.env`
file with the appropriate environment variables, and then run the following:

```
$ docker run -v "PATH_TO_BOOK:/data/src" --env-file .env --rm robles bin/robles publish
```

## Development

You can use the `docker-compose.yml` file to build and run __robles__, but it assumes the following
directory structure:

```
 |-books
 | |-ia     [the iOS apprentice repo]
 |-...      [any name]
   |-robles [this repo]
```

Then to get a shell:

```
$ docker-compose run --rm --service-ports app bash
```

You can then use `bin/robles` to see the different CLI options available, including the `publish`
command, which will generate the book and then upload it to `alexandria`.

