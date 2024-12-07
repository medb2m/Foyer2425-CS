# Étape 1 : Utiliser une image Maven pour télécharger le JAR depuis Nexus
FROM maven:3.9.5-eclipse-temurin-17 AS builder

# Définir les variables d'environnement pour Nexus
ARG NEXUS_URL=http://77.37.125.190:8081/repository/maven-releases/
ARG GROUP_ID=tn.esprit.spring
ARG ARTIFACT_ID=Foyer
ARG VERSION=1.4.0-SNAPSHOT

# Créer un dossier de travail
WORKDIR /test

# copier le fichier settings dans le conteneur
COPY settings.xml /root/.m2/settings.xml

# Télécharger l'artefact JAR depuis Nexus
RUN mvn dependency:get -DrepoUrl=$NEXUS_URL \
    -Dartifact=$GROUP_ID:$ARTIFACT_ID:$VERSION:jar \
    -Dtransitive=false && \
    mvn dependency:copy -Dartifact=$GROUP_ID:$ARTIFACT_ID:$VERSION:jar -DoutputDirectory=/test

# Étape 2 : Utiliser une image JDK minimale pour exécuter l'application
FROM eclipse-temurin:17-jre

# Copier le JAR depuis l'étape précédente
COPY --from=builder /app/devopsProject-1.0.0-RELEASE.jar /test/application.jar

# Définir le port exposé par le conteneur
EXPOSE 8089

# Définir la commande de démarrage
ENTRYPOINT ["java", "-jar", "/test/application.jar"]
