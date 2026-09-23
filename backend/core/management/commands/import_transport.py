from django.core.management.base import BaseCommand

from core import transport_data


class Command(BaseCommand):
    help = "Import Astana districts, bus/rail stops, Zenodo bus routes and the population model into Postgres."

    def handle(self, *args, **options):
        transport_data.run(log=lambda msg: self.stdout.write(msg))
