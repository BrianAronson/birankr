import setuptools
from distutils.core import setup

with open("pypi_readme.md", "r") as fh:
    long_description = fh.read()

setup(name='birankpy',
      version='0.1.1',
      description = 'Ranking nodes in bipartite networks with efficiency and flexibility',
      long_description=long_description,
      long_description_content_type='text/markdown',
      author = 'Kaicheng Yang',
      author_email = 'yangkc@iu.edu',
      url="https://github.com/BrianAronson/birankr",
      license = 'MIT',
      install_requires=[
          'networkx',
          'pandas',
          'numpy',
          'scipy'
      ],
      packages = ['birankpy']
)
