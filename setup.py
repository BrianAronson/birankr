import setuptools
from distutils.core import setup

setup(name='birankpy',
      version='0.1',
      description = 'Ranking nodes in bipartite networks',
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
