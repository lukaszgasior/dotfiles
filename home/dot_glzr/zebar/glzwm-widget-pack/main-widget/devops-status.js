export async function checkDevOpsStatus() {
    try {
        const response = await fetch(`http://localhost:8787/devops-status?t=${Date.now()}`, {
            cache: 'no-store',
            headers: {
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache'
            }
        });
        const text = await response.text();
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(text, "text/xml");

        const items = xmlDoc.getElementsByTagName('item');
        let status = {
            hasIssues: false,
            issues: []
        };

        if (items.length > 0) {
            for (let i = 0; i < items.length; i++) {
                const item = items[i];
                const state = item.getElementsByTagNameNS('*', 'state')[0]?.textContent || '';

                // Only consider issues that are not resolved
                if (state !== 'Resolved') {
                    status.hasIssues = true;
                    status.issues.push({
                        title: item.getElementsByTagName('title')[0]?.textContent || '',
                        description: item.getElementsByTagName('description')[0]?.textContent || '',
                        pubDate: item.getElementsByTagName('pubDate')[0]?.textContent || '',
                        state: state
                    });
                }
            }
        }

        console.log("Azure DevOps status:", status);

        return status;
    } catch (error) {
        console.error('Error fetching Azure DevOps status:', error);
        return { hasIssues: false, error: true };
    }
}
