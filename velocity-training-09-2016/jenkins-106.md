
## Jenkins 106 - Advanced Pipelines

The Groovy Pipeline syntax is fairly complicated, a fair bit different from shell scripts.

Pipeline Resources:

- Basic Pipeline Groovy Syntax: <https://jenkins.io/doc/pipeline/#basic-groovy-syntax-for-pipeline-configuration>
- Pipeline Steps Reference: <https://jenkins.io/doc/pipeline/steps/>
- Official Pipeline Plugin Tutorial: <https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md>
- Pipeline Best Practices: <https://github.com/jenkinsci/pipeline-examples/blob/master/docs/BEST_PRACTICES.md>


Install Plugin `Pipeline Utility Steps` to get `readProperties` function.
1. Select `Install without Restart`

Jenkins uses a Groovy sandbox to execute pipeline scripts. This sandbox has a whitelist of approved classes and functions for security, but sometimes the default functions just aren't enough. So when using unapproved classes or functions in a build, an approval request will be added to a queue for an admin to approve.

For example, to approve the use of `Arrays.asList`:

1. Run a pipeline build that uses `Arrays.asList`
1. Select `Manage Jenkins` to open the management page
1. Select `In-process Script Approval` to open the script approval page
1. Approve `staticMethod java.util.Arrays asList java.lang.Object[]`
1. Re-run the pipeline build and watch is succeed!

Examples:

```
method java.util.Collection clear
new java.util.ArrayList
new java.util.ArrayList java.util.Collection
staticMethod java.util.Arrays asList java.lang.Object[]
staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods addAll java.util.Collection java.lang.Object[]
staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods plus java.util.List java.lang.Object
```

```
def build_env_file = '.env'

node {
  stage 'Build'
  git url: 'http://github.com/karlkfi/minitwit', branch: 'ci'

  withEnv(["OUT_FILE=${build_env_file}"]) {
    sh 'ci/build.sh'
  }

  def build_props = readProperties file: build_env_file

  stash name: 'build-output', includes: "${build_env_file},${build_props['DOCKER_IMG_TAR']}"
}
// checkpoint 'Completed Build'
node {
  stage 'Test'
  git url: 'http://github.com/karlkfi/minitwit', branch: 'ci'

  unstash name: 'build-output'

  def build_env = new ArrayList()
  build_env.add "OUT_FILE=${build_env_file}"
  build_env.addAll Arrays.asList(readFile(build_env_file).split('\n'))

  try {
    withEnv(build_env) {
      sh 'ci/run.sh'
    }
  } finally {
    build_env.clear()
    build_env.addAll Arrays.asList(readFile(build_env_file).split('\n'))
    withEnv(build_env) {
      sh 'ci/cleanup.sh'
    }
  }
}
```

TODO: Checkpoints (CloudBees paid feature): https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/chapter-workflow.html?q=checkpoints

## Back to Index

[Velocity Training](README.md)
