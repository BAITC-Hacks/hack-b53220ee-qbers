from django.core.management.base import BaseCommand

from core import open_data


class Command(BaseCommand):
    help = "Download open data (cached in data/raw/), rebuild the reference tables and write core/fixtures/open_data.json.gz."

    def handle(self, *args, **options):
        open_data.run(log=lambda msg: self.stdout.write(msg))
