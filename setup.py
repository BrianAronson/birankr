import setuptools
from distutils.core import setup

with open("pypi_readme.md", "r") as fh:
    long_description = fh.read()

setup(name='birankpy',
      version='1.0.1',
      description = 'Ranking nodes in bipartite networks with efficiency and flexibility',
      long_description=long_description,
      long_description_content_type='text/markdown',
      author = 'Kaicheng Yang',
      author_email = 'yangkc@iu.edu',
      url="https://github.com/BrianAronson/birankr",
      license = 'MIT',
      install_requires=[
          'networkx>=2.5',
          'pandas>=0.23.4',
          'numpy>=1.16.2',
          'scipy>=1.2.0'
      ],
      packages = ['birankpy']
)
