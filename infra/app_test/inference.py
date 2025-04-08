import os

from dotenv import load_dotenv


def main():

    load_dotenv()

    my_env = os.getenv('S3_ACCESS_KEY')

    print(my_env)


if __name__ == "__main__":

    main()
