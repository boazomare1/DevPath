enum SkillCategory {
  programmingLanguages,
  frameworks,
  databases,
  testing,
  devops,
  systemDesign,
  softSkills;

  String get displayName {
    switch (this) {
      case SkillCategory.programmingLanguages:
        return 'Programming Languages';
      case SkillCategory.frameworks:
        return 'Frameworks & Libraries';
      case SkillCategory.databases:
        return 'Databases';
      case SkillCategory.testing:
        return 'Testing';
      case SkillCategory.devops:
        return 'DevOps & Tools';
      case SkillCategory.systemDesign:
        return 'System Design';
      case SkillCategory.softSkills:
        return 'Soft Skills';
    }
  }

  String get description {
    switch (this) {
      case SkillCategory.programmingLanguages:
        return 'Core programming languages and their ecosystems';
      case SkillCategory.frameworks:
        return 'Frameworks, libraries, and development tools';
      case SkillCategory.databases:
        return 'Database technologies and data management';
      case SkillCategory.testing:
        return 'Testing methodologies and tools';
      case SkillCategory.devops:
        return 'DevOps practices, CI/CD, and infrastructure';
      case SkillCategory.systemDesign:
        return 'System architecture and design patterns';
      case SkillCategory.softSkills:
        return 'Communication, leadership, and collaboration';
    }
  }

  String get icon {
    switch (this) {
      case SkillCategory.programmingLanguages:
        return '💻';
      case SkillCategory.frameworks:
        return '⚛️';
      case SkillCategory.databases:
        return '🗄️';
      case SkillCategory.testing:
        return '🧪';
      case SkillCategory.devops:
        return '🔧';
      case SkillCategory.systemDesign:
        return '🏗️';
      case SkillCategory.softSkills:
        return '🤝';
    }
  }
}
