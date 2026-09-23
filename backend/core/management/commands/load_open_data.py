from django.core.management.base import BaseCommand

from core import open_data


class Command(BaseCommand):
    help = "Load the committed open-data fixture into Postgres if any reference table is empty (offline)."

    def add_arguments(self, parser):
        parser.add_argument("--force", action="store_true", help="Reload even if the tables already have data.")

    def handle(self, *args, **options):
        open_data.load_fixture(force=options["force"], log=lambda msg: self.stdout.write(msg))
